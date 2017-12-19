Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A237F6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:48:23 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id x62so4467390ioe.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:48:23 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id j8si1479824iti.128.2017.12.19.07.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:48:22 -0800 (PST)
Date: Tue, 19 Dec 2017 09:48:21 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 4/8] mm: Improve comment on page->mapping
In-Reply-To: <20171219080233.GA2787@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1712190948090.16727@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-5-willy@infradead.org> <20171219080233.GA2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
