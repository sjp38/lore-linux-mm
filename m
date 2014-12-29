Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF7B6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 05:07:36 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so18495403wgh.4
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 02:07:35 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id d8si71849079wjy.80.2014.12.29.02.07.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 02:07:34 -0800 (PST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 29 Dec 2014 10:07:33 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 09FBF1B08061
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:08:00 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sBTA7Us063045682
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:07:30 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sBTA7TcI001393
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 03:07:30 -0700
Date: Mon, 29 Dec 2014 11:07:27 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 30/38] s390: drop pte_file()-related helpers
Message-ID: <20141229110727.75afa56d@mschwide>
In-Reply-To: <1419423766-114457-31-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1419423766-114457-31-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>

On Wed, 24 Dec 2014 14:22:38 +0200
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
> @@ -279,7 +279,6 @@ static inline int is_module_addr(void *addr)
>   *
>   * pte_present is true for the bit pattern .xx...xxxxx1, (pte & 0x001) == 0x001
>   * pte_none    is true for the bit pattern .10...xxxx00, (pte & 0x603) == 0x400
> - * pte_file    is true for the bit pattern .11...xxxxx0, (pte & 0x601) == 0x600
>   * pte_swap    is true for the bit pattern .10...xxxx10, (pte & 0x603) == 0x402
>   */
 
Nice, once this is upstream I can free up one of the software bits in
the pte by redefining the type bits. Right now all of them are used up.
Is the removal of non-linear mappings a done deal ?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
