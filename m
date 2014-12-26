Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 25FBD6B006E
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 00:52:29 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id gd6so8612794lab.1
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 21:52:28 -0800 (PST)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com. [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id o12si30500305lal.38.2014.12.25.21.52.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Dec 2014 21:52:27 -0800 (PST)
Received: by mail-la0-f51.google.com with SMTP id ms9so8439245lab.38
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 21:52:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141225123014.GO16916@distanz.ch>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1419423766-114457-27-git-send-email-kirill.shutemov@linux.intel.com>
	<20141225123014.GO16916@distanz.ch>
Date: Fri, 26 Dec 2014 13:52:27 +0800
Message-ID: <CAFiDJ59P7DPTfBN5PrhXjTLhku0U+ZYBv_0qdmjtbBNN0T2h3A@mail.gmail.com>
Subject: Re: [PATCH 26/38] nios2: drop _PAGE_FILE and pte_file()-related helpers
From: Ley Foon Tan <lftan@altera.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Klauser <tklauser@distanz.ch>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Linux-Arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 25, 2014 at 8:30 PM, Tobias Klauser <tklauser@distanz.ch> wrote:
> On 2014-12-24 at 13:22:34 +0100, Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
>> We've replaced remap_file_pages(2) implementation with emulation.
>> Nobody creates non-linear mapping anymore.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Ley Foon Tan <lftan@altera.com>
>
> Reviewed-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Ley Foon Tan <lftan@altera.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
