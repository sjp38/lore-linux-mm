Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f80.google.com (mail-pa0-f80.google.com [209.85.220.80])
	by kanga.kvack.org (Postfix) with ESMTP id 5023E6B0035
	for <linux-mm@kvack.org>; Sat, 16 Nov 2013 09:46:25 -0500 (EST)
Received: by mail-pa0-f80.google.com with SMTP id kx10so45830pab.7
        for <linux-mm@kvack.org>; Sat, 16 Nov 2013 06:46:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id kn3si1368626pbc.64.2013.11.15.00.36.41
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 00:36:42 -0800 (PST)
Message-ID: <5285DD15.6080700@iki.fi>
Date: Fri, 15 Nov 2013 10:36:37 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Early use of boot service memory
References: <1384222558-38527-1-git-send-email-jerry.hoemann@hp.com> <d73ccce9-6a0d-4470-bda3-f0c6eb96b5e4@email.android.com> <20131113224503.GB25344@anatevka.fc.hp.com> <52840206.5020006@zytor.com> <20131113235708.GC25344@anatevka.fc.hp.com> <CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com> <20131114180455.GA32212@anatevka.fc.hp.com> <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com> <20131115005049.GJ5116@anatevka.fc.hp.com>
In-Reply-To: <20131115005049.GJ5116@anatevka.fc.hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>linux-doc@vger.kernel.org, linux-efi@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 11/15/13 2:50 AM, jerry.hoemann@hp.com wrote:
> One already has to specify command line arguments to enable kdump.

Yes, so what?

The problem with your patch is that now to enable kdump, I have to know 
that there's a second command line option and if my firmware is "broken" 
or not.  The former is already a problem (how do I even know such a 
thing exists?) but the latter is almost impossible to solve from user 
point of view. And if I have a "broken" firmware, kdump won't work no 
matter what options I pass.

I really don't see what's practical about that.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
