Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C64786B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 02:46:40 -0400 (EDT)
Message-Id: <4E4245A8020000780005084E@nat28.tlf.novell.com>
Date: Wed, 10 Aug 2011 07:47:36 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
	 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com>
 <4E414320020000780005057E@nat28.tlf.novell.com><4E414320020000780005057E@nat28.tlf.novell.com>
 <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default
 4E4179D90200007800050676@nat28.tlf.novell.com><4E4179D90200007800050676@nat28.tlf.novell.com>
 <747e657f-24be-41ed-a251-36116c8a6a13@default>
In-Reply-To: <747e657f-24be-41ed-a251-36116c8a6a13@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

>>> On 09.08.11 at 19:43, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
> Anyway, unless you feel very strongly about this, I'm
> inclined to not add the ifdef to the struct for the
> reasons previously stated.

No, I don't feel really strongly about this - it you can get it accepted =
with
the minor overhead, that's fine to me. It's just that for integration into
our kernels (i.e. until these get accepted upstream) I chose to do those
adjustments to avoid possible complaints.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
