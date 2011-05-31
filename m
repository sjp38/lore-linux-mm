Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 99C0A6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 05:26:23 -0400 (EDT)
Message-ID: <4DE4B432.1090203@fnarfbargle.com>
Date: Tue, 31 May 2011 17:26:10 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic>
In-Reply-To: <20110531054729.GA16852@liondog.tnic>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 31/05/11 13:47, Borislav Petkov wrote:
> Looks like a KSM issue. Disabling CONFIG_KSM should at least stop your
> machine from oopsing.
>
> Adding linux-mm.
>

I initially thought that, so the second panic was produced with KSM 
disabled from boot.

echo 0 > /sys/kernel/mm/ksm/run

If you still think that compiling ksm out of the kernel will prevent it 
then I'm willing to give it a go.

It's a production server, so I can only really bounce it around after 
about 9PM - GMT+8.

Regards,
Brad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
