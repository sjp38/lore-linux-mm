Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDB78E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:39:01 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s22so17190233pgv.8
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:39:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h5si17341188pfg.233.2018.12.19.09.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 09:39:00 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBJHTuRd050076
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:38:59 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pfte30e52-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:38:59 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 19 Dec 2018 17:38:57 -0000
Date: Wed, 19 Dec 2018 18:38:52 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] s390: remove the ptep_modify_prot_{start,commit} exports
References: <20181219150750.4798-1-hch@lst.de>
MIME-Version: 1.0
In-Reply-To: <20181219150750.4798-1-hch@lst.de>
Message-Id: <20181219173852.GA3789@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: schwidefsky@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 19, 2018 at 04:07:50PM +0100, Christoph Hellwig wrote:
> These two functions are only used by core MM code, so no need to export
> them.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/s390/mm/pgtable.c | 2 --
>  1 file changed, 2 deletions(-)

Applied, thanks.
