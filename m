Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E05F22806CB
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:25:13 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y77so3723274wrb.22
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:25:13 -0700 (PDT)
Received: from mail-wr0-x232.google.com (mail-wr0-x232.google.com. [2a00:1450:400c:c0c::232])
        by mx.google.com with ESMTPS id q27si8696180wra.35.2017.03.29.08.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 08:25:12 -0700 (PDT)
Received: by mail-wr0-x232.google.com with SMTP id w43so20107157wrb.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:25:12 -0700 (PDT)
Date: Wed, 29 Mar 2017 18:00:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 6/8] x86/dump_pagetables: Add support 5-level paging
Message-ID: <20170329150010.dy47s4kcqsv4dmgz@node.shutemov.name>
References: <20170328093946.GA30567@gmail.com>
 <20170328104806.41711-1-kirill.shutemov@linux.intel.com>
 <20170328185522.5akqgfh4niqi3ptf@pd.tnic>
 <20170328211507.ungejuigkewn6prl@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328211507.ungejuigkewn6prl@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 29, 2017 at 12:15:07AM +0300, Kirill A. Shutemov wrote:
> I'll try to look more into this issue tomorrow.

Putting this commit before seems f2a6a7050109 ("x86: Convert the rest of
the code to support p4d_t") seems fixes the issue.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
