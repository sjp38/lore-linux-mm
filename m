Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A99D98E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:10:00 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g7so8214882plp.10
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 05:10:00 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 6si10160054plc.241.2018.12.10.05.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 05:09:59 -0800 (PST)
Date: Mon, 10 Dec 2018 16:09:54 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 0/2] Fixups for LDT remap placement change
Message-ID: <20181210130954.fsvir26ivenythex@black.fi.intel.com>
References: <20181130202328.65359-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130202328.65359-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, hans.van.kranenburg@mendix.com, x86@kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org

On Fri, Nov 30, 2018 at 08:23:26PM +0000, Kirill A. Shutemov wrote:
> There's a couple fixes for the recent LDT remap placement change.

Ping?

-- 
 Kirill A. Shutemov
