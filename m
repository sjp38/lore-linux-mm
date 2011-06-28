Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C48476B00E9
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 14:22:32 -0400 (EDT)
Received: by fxh2 with SMTP id 2so552926fxh.9
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 11:22:29 -0700 (PDT)
From: Maciej Rutecki <maciej.rutecki@gmail.com>
Reply-To: maciej.rutecki@gmail.com
Subject: Re: slab vs lockdep vs debugobjects
Date: Tue, 28 Jun 2011 20:22:22 +0200
References: <1308592080.26237.114.camel@twins> <201106262204.25710.maciej.rutecki@gmail.com> <1309124100.4756.0.camel@twins>
In-Reply-To: <1309124100.4756.0.camel@twins>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106282022.23269.maciej.rutecki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On niedziela, 26 czerwca 2011 o 23:35:00 Peter Zijlstra wrote:
> On Sun, 2011-06-26 at 22:04 +0200, Maciej Rutecki wrote:
> > I created a Bugzilla entry at
> > https://bugzilla.kernel.org/show_bug.cgi?id=36912
> > for your bug report, please add your address to the CC list in there,
> > thanks!
> 
> How the hell does that improve things?
Sorry for the noise, I wrong assumed that is regression, and problem does not 
occured before. Rafael already removed it from regression list.

Regards
-- 
Maciej Rutecki
http://www.maciek.unixy.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
