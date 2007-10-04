Date: Wed, 3 Oct 2007 20:54:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] hugetlb: search harder for memory in alloc_fresh_huge_page()
In-Reply-To: <20071003224538.GB29663@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0710032053200.4560@schroedinger.engr.sgi.com>
References: <20071003224538.GB29663@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, anton@samba.org, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Oct 2007, Nishanth Aravamudan wrote:

> Christoph, I've moved to using a global static variable, is this closer
> to what you hoped for?

Looks good now.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
