Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E5F816B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 17:02:28 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id g62so39858814wme.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:02:28 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id mb1si14776093wjb.176.2016.02.11.14.02.27
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 14:02:27 -0800 (PST)
Date: Thu, 11 Feb 2016 23:02:22 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v11 0/4] Machine check recovery when kernel accesses
 poison
Message-ID: <20160211220222.GJ5565@pd.tnic>
References: <cover.1455225826.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cover.1455225826.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Thu, Feb 11, 2016 at 01:34:10PM -0800, Tony Luck wrote:
> This series is initially targeted at the folks doing filesystems
> on top of NVDIMMs. They really want to be able to return -EIO
> when there is a h/w error (just like spinning rust, and SSD does).
> 
> I plan to use the same infrastructure to write a machine check aware
> "copy_from_user()" that will SIGBUS the calling application when a
> syscall touches poison in user space (just like we do when the application
> touches the poison itself).
> 
> I've dropped off the "reviewed-by" tags that I collected back prior to
> adding the new field to the exception table. Please send new ones
> if you can.
> 
> Changes

That's some changelog, I tell ya. Well, it took us long enough so for
all 4:

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
