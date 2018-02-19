Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7F976B000C
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 09:54:39 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 6so8913728iti.4
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 06:54:39 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id v26si6119169iob.292.2018.02.19.06.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 06:54:38 -0800 (PST)
Date: Mon, 19 Feb 2018 08:54:34 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 2/2] Page order diagnostics
In-Reply-To: <20180217211725.GA9640@amd>
Message-ID: <alpine.DEB.2.20.1802190854140.22119@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.583566579@linux.com> <20180217211725.GA9640@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

n Sat, 17 Feb 2018, Pavel Machek wrote:

> I don't think this does what you want it to do. Commas are missing.

Right never tested on anything but x86.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
