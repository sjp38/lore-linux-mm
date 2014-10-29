Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id D1EDC900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 23:06:18 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id tr6so2160687ieb.14
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 20:06:18 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0148.hostedemail.com. [216.40.44.148])
        by mx.google.com with ESMTP id 4si4601727iot.91.2014.10.28.20.06.17
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 20:06:18 -0700 (PDT)
Message-ID: <1414551974.10912.16.camel@perches.com>
Subject: Re: [PATCH] 6fire: Convert byte_rev_table uses to bitrev8
From: Joe Perches <joe@perches.com>
Date: Tue, 28 Oct 2014 20:06:14 -0700
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D1825C@CNBJMBX05.corpusers.net>
References: 
	<35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
	 <1414392371.8884.2.camel@perches.com>
	 <1414531369.10912.14.camel@perches.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1825C@CNBJMBX05.corpusers.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, Russell King <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, alsa-devel <alsa-devel@alsa-project.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2014-10-29 at 10:42 +0800, Wang, Yalin wrote:
> > Use the inline function instead of directly indexing the array.
> > This allows some architectures with hardware instructions for bit reversals
> > to eliminate the array.
[]
> > On Sun, 2014-10-26 at 23:46 -0700, Joe Perches wrote:
> > > On Mon, 2014-10-27 at 14:37 +0800, Wang, Yalin wrote:
> > > > this change add CONFIG_HAVE_ARCH_BITREVERSE config option, so that
> > > > we can use arm/arm64 rbit instruction to do bitrev operation by
> > > > hardware.
[]
> I think the most safe way is change byte_rev_table[] to be satic,
> So that no driver can access it directly,
> The build error can remind the developer if they use byte_rev_table[]
> Directly .

You can do that with your later patch, but the
existing uses _must_ be converted first so you
don't break the build.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
