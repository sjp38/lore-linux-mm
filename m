Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2DB946B0022
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:22:44 -0400 (EDT)
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
From: Joe Perches <joe@perches.com>
In-Reply-To: <op.vvlj1vad3l0zgt@mnazarewicz-glaptop>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
	 <1305580757-13175-4-git-send-email-john.stultz@linaro.org>
	 <op.vvlfaobx3l0zgt@mnazarewicz-glaptop>
	 <alpine.DEB.2.00.1105161431550.4353@chino.kir.corp.google.com>
	 <1305587090.2503.42.camel@Joe-Laptop>
	 <op.vvlj1vad3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 16:22:41 -0700
Message-ID: <1305588161.2503.46.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: David Rientjes <rientjes@google.com>, Andy Whitcroft <apw@canonical.com>, LKML <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-17 at 01:11 +0200, Michal Nazarewicz wrote:
> On Tue, 17 May 2011 01:04:50 +0200, Joe Perches <joe@perches.com> wrote:
> > On Mon, 2011-05-16 at 14:34 -0700, David Rientjes wrote:
> >> On Mon, 16 May 2011, Michal Nazarewicz wrote:
> >> > > Now that accessing current->comm needs to be protected,
> >> > > +# check for current->comm usage
> >> > > +		if ($line =~ /\b(?:current|task|tsk|t)\s*->\s*comm\b/) {
> >> > Not a checkpatch.pl expert but as far as I'm concerned, that looks  
> >> reasonable.
> > You don't need (?: just (
> Yep, it's a micro-optimisation though.

True, but it's not the common style in checkpatch.
You could submit patches to add non-capture markers to other () uses.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
