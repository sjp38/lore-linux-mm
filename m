Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id C53516B006E
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:19:02 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id s18so2193697lam.5
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:19:02 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id jo9si6655368wjc.128.2015.01.22.07.19.00
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 07:19:00 -0800 (PST)
Date: Thu, 22 Jan 2015 17:18:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: remove rest usage of VM_NONLINEAR and pte_file()
Message-ID: <20150122151857.GA31371@node.dhcp.inet.fi>
References: <20150122132813.GA15803@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122132813.GA15803@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On Thu, Jan 22, 2015 at 04:28:13PM +0300, Dan Carpenter wrote:
> Hello Kirill A. Shutemov,
> 
> The patch 05864bbd92f9: "mm: remove rest usage of VM_NONLINEAR and
> pte_file()" from Jan 17, 2015, leads to the following static checker
> warning:
> 
> 	mm/memcontrol.c:4794 mc_handle_file_pte()
> 	warn: passing uninitialized 'pgoff'

Please test the patch below.
