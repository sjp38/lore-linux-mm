Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBBA6B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 17:08:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n5-v6so2912761plp.16
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 14:08:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v18-v6si6018188pfa.3.2018.11.02.14.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 14:08:52 -0700 (PDT)
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9A3ED2084D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 21:08:51 +0000 (UTC)
Received: by mail-wm1-f47.google.com with SMTP id v24-v6so3104962wmh.3
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 14:08:51 -0700 (PDT)
MIME-Version: 1.0
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com> <20181026122856.66224-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181026122856.66224-4-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 2 Nov 2018 14:08:38 -0700
Message-ID: <CALCETrUe7nNxbpHJaO0mKS3g8RvL0am4WnKOofei8fviK-PgEg@mail.gmail.com>
Subject: Re: [PATCHv3 3/3] x86/ldt: Remove unused variable in map_ldt_struct()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Baoquan He <bhe@redhat.com>, Matthew Wilcox <willy@infradead.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 26, 2018 at 5:29 AM Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> Commit
>
>   9bae3197e15d ("x86/ldt: Split out sanity check in map_ldt_struct()")
>
> moved page table syncing into a separate funtion. pgd variable is now
> unsed in map_ldt_struct().

Reviewed-by: Andy Lutomirski <luto@kernel.org>
