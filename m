Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DFB996B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:31:41 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x125so10556908pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:31:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d9si11491362pas.186.2016.01.27.12.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 12:31:32 -0800 (PST)
Date: Wed, 27 Jan 2016 12:31:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Message-Id: <20160127123131.2be09678d5b477386497ade7@linux-foundation.org>
In-Reply-To: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Fri,  8 Jan 2016 14:49:44 -0500 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Andrew, I think this is ready for a spin in -mm.

Let's see what happens.

Just from eyeballing the patches, I'm expecting build errors ;) I'm
about to vanish until Monday so please cc Stephen on any fixes so he
can get linux-next back into shape.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
