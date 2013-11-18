Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E4A3C6B0037
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 13:52:35 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so5562825pab.9
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:52:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id n5si10375115pav.11.2013.11.18.10.52.30
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 10:52:31 -0800 (PST)
Date: Mon, 18 Nov 2013 13:52:24 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
Message-ID: <20131118185224.GD32168@redhat.com>
References: <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
 <5285C639.5040203@zytor.com>
 <20131115140738.GB6637@redhat.com>
 <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
 <52865CA1.5020309@zytor.com>
 <20131115183002.GE6637@redhat.com>
 <52866C0D.3050006@zytor.com>
 <52867309.4040406@zytor.com>
 <20131118152255.GA32168@redhat.com>
 <528A5C7E.5080007@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <528A5C7E.5080007@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 18, 2013 at 10:29:18AM -0800, H. Peter Anvin wrote:
> On 11/18/2013 07:22 AM, Vivek Goyal wrote:
> > 
> > And if that's true, then reserving 72M extra due to crashkernel=X,high
> > should not be a big issue in KVM guests. It will still be an issue on
> > physical servers though.
> > 
> 
> Yes, but there it is a single instance and not a huge amount of RAM.

Agreed. But for some people it is. For example, we don't enable kdump
by default on fedora. Often people don't like 128MB of their laptop
memory not being used. And I have been thinking how to reduce memory
usage further so that I can enable kdump by default on Fedora.

Instead, now this 72MB increase come in picture which does not bring
us any benefit for most of the people. Only people who benefit from
it are large memory servers and everybody else (having memory more
than 4G) pays this penalty.

I rather prefer that this penalty of 72M is paid only by those who need
to have memory reservation above 4G.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
