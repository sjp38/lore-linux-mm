Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id BC0876B002C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 03:05:55 -0500 (EST)
Received: by obbta7 with SMTP id ta7so1334430obb.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 00:05:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1201200848040.25882@router.home>
References: <1326558605.19951.7.camel@lappy>
	<1326561043.5287.24.camel@edumazet-laptop>
	<1326632384.11711.3.camel@lappy>
	<1326648305.5287.78.camel@edumazet-laptop>
	<alpine.DEB.2.00.1201170910130.4800@router.home>
	<1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170927020.4800@router.home>
	<1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170942240.4800@router.home>
	<alpine.DEB.2.00.1201171620590.14697@router.home>
	<m1bopz2ws3.fsf@fess.ebiederm.org>
	<m14nvr2vbu.fsf@fess.ebiederm.org>
	<alpine.DEB.2.00.1201191959540.14480@router.home>
	<m1y5t3yuil.fsf@fess.ebiederm.org>
	<alpine.DEB.2.00.1201200848040.25882@router.home>
Date: Wed, 1 Feb 2012 10:05:54 +0200
Message-ID: <CAOJsxLFtvJbNUkXbesXdu39CwyrRrb0yT2jjWtj7m7R0GSr=YA@mail.gmail.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

On Fri, Jan 20, 2012 at 4:49 PM, Christoph Lameter <cl@linux.com> wrote:
> Ok then I guess my last patch is needed to make sysfs operations safe.

Hmm. So is the latter patch needed or not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
