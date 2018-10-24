Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A21B26B027B
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 07:12:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r81-v6so3048984pfk.11
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:12:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s12-v6si4090344plr.307.2018.10.24.04.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 04:12:44 -0700 (PDT)
Date: Wed, 24 Oct 2018 04:12:25 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] x86/ldt: Unmap PTEs for the slow before freeing LDT
Message-ID: <20181024111225.GA5807@infradead.org>
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
 <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The subject line does not parse..
