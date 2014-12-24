Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DEAEB6B0071
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 09:03:37 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so10116075pad.31
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 06:03:37 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ih5si13845366pbc.83.2014.12.24.06.03.34
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 06:03:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-8-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-8-git-send-email-kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 07/38] mm: remove rest usage of VM_NONLINEAR and pte_file()
Content-Transfer-Encoding: 7bit
Message-Id: <20141224140205.92CDBA6@black.fi.intel.com>
Date: Wed, 24 Dec 2014 16:02:05 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

