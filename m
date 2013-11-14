Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 109426B003B
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 13:46:12 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so809830pdj.2
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 10:46:12 -0800 (PST)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id yg5si8173087pbc.296.2013.11.14.10.46.08
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 10:46:09 -0800 (PST)
Message-ID: <52851A56.1040709@zytor.com>
Date: Thu, 14 Nov 2013 10:45:42 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Early use of boot service memory
References: <1384222558-38527-1-git-send-email-jerry.hoemann@hp.com>	<d73ccce9-6a0d-4470-bda3-f0c6eb96b5e4@email.android.com>	<20131113224503.GB25344@anatevka.fc.hp.com>	<52840206.5020006@zytor.com>	<20131113235708.GC25344@anatevka.fc.hp.com>	<CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>	<20131114180455.GA32212@anatevka.fc.hp.com> <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
In-Reply-To: <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Jerry Hoemann <jerry.hoemann@hp.com>
Cc: Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>linux-doc@vger.kernel.org, linux-efi@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 11/14/2013 10:44 AM, Pekka Enberg wrote:
> On Thu, Nov 14, 2013 at 8:04 PM,  <jerry.hoemann@hp.com> wrote:
>> Making this issue a quirk will be a lot more practical.  Its a small, focused
>> change whose implications are limited and more easily understood.
> 
> There's nothing practical with requiring users to pass a kernel option
> to make kdump work.  It's a workaround, sure, but it's not a proper
> fix.

And once you have to do that anyway, you might as well just do the kdump
load high...

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
