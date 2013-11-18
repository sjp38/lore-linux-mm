Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DAF6A6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 13:29:47 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so1306115pab.4
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:29:47 -0800 (PST)
Received: from psmtp.com ([74.125.245.126])
        by mx.google.com with SMTP id yd9si10311224pab.89.2013.11.18.10.29.43
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 10:29:45 -0800 (PST)
Message-ID: <528A5C7E.5080007@zytor.com>
Date: Mon, 18 Nov 2013 10:29:18 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Early use of boot service memory
References: <20131115005049.GJ5116@anatevka.fc.hp.com> <20131115062417.GB9237@gmail.com> <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com> <5285C639.5040203@zytor.com> <20131115140738.GB6637@redhat.com> <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com> <52865CA1.5020309@zytor.com> <20131115183002.GE6637@redhat.com> <52866C0D.3050006@zytor.com> <52867309.4040406@zytor.com> <20131118152255.GA32168@redhat.com>
In-Reply-To: <20131118152255.GA32168@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 11/18/2013 07:22 AM, Vivek Goyal wrote:
> 
> And if that's true, then reserving 72M extra due to crashkernel=X,high
> should not be a big issue in KVM guests. It will still be an issue on
> physical servers though.
> 

Yes, but there it is a single instance and not a huge amount of RAM.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
