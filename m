Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDEEB6B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:53:52 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id x32so6969955ita.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:53:52 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id a8si1468639itg.78.2017.12.19.07.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:53:52 -0800 (PST)
Date: Tue, 19 Dec 2017 09:53:51 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 8/8] mm: Remove reference to PG_buddy
In-Reply-To: <20171219100226.GG2787@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1712190953350.16727@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-9-willy@infradead.org> <20171219100226.GG2787@dhcp22.suse.cz>
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
