Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8E67B6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:35:16 -0400 (EDT)
Message-ID: <1337290512.4281.91.camel@twins>
Subject: Re: [PATCH 1/2] lib: Proportions with flexible period
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 May 2012 23:35:12 +0200
In-Reply-To: <1337096583-6049-2-git-send-email-jack@suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
	 <1337096583-6049-2-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> +               if (numerator > ((long long)denominator) * max_frac / 100=
)

Does that even compile on 32bit archs?

Operator precedence is *,/ left-to-right, so that's:

  long long t1 =3D (long long)denom * max_frac
  long long t2 =3D t1 / 100;

Which is a 64bit signed division.

There's a reason I used that max_prop_frac thing you removed, it avoids
having to do the division at all and allows a mult and shift instead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
