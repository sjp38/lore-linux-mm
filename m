Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A31506B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 01:30:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id s4so35709253wrc.15
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 22:30:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k88si13336731wmi.131.2017.06.13.22.30.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 22:30:36 -0700 (PDT)
Subject: Re: [PATCH v2 09/10] x86/mm: Enable CR4.PCIDE on supported systems
References: <cover.1497415951.git.luto@kernel.org>
 <9cbc7f6c85a865f544adc6141951059e5aff7309.1497415951.git.luto@kernel.org>
From: Juergen Gross <jgross@suse.com>
Message-ID: <37ff0036-e33c-84d2-2c5d-8c85d1245064@suse.com>
Date: Wed, 14 Jun 2017 07:30:32 +0200
MIME-Version: 1.0
In-Reply-To: <9cbc7f6c85a865f544adc6141951059e5aff7309.1497415951.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 14/06/17 06:56, Andy Lutomirski wrote:
> We can use PCID if the CPU has PCID and PGE and we're not on Xen.
> 
> By itself, this has no effect.  The next patch will start using
> PCID.
> 
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Juergen Gross <jgross@suse.com>


Thanks,

Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
