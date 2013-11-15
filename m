Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 55D646B0037
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 01:59:28 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so3190393pbc.10
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 22:59:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.134])
        by mx.google.com with SMTP id bc2si1129915pad.42.2013.11.14.22.59.25
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 22:59:25 -0800 (PST)
Message-ID: <5285C639.5040203@zytor.com>
Date: Thu, 14 Nov 2013 22:59:05 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Early use of boot service memory
References: <1384222558-38527-1-git-send-email-jerry.hoemann@hp.com>	<d73ccce9-6a0d-4470-bda3-f0c6eb96b5e4@email.android.com>	<20131113224503.GB25344@anatevka.fc.hp.com>	<52840206.5020006@zytor.com>	<20131113235708.GC25344@anatevka.fc.hp.com>	<CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>	<20131114180455.GA32212@anatevka.fc.hp.com>	<CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>	<20131115005049.GJ5116@anatevka.fc.hp.com>	<20131115062417.GB9237@gmail.com> <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
In-Reply-To: <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>linux-doc@vger.kernel.org, linux-efi@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 11/14/2013 10:55 PM, Yinghai Lu wrote:
> 
> Why just asking distros to append ",high" in their installation
> program for 64bit by default?
> 
[...]
> 
> What is hpa's suggestion?
> 

Pretty much what you just said ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
