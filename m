Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45C256B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:54:59 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id k188so6734787qkc.18
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:54:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q2si1900797qkq.13.2018.01.30.02.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 02:54:58 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0UAsTiu011630
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:54:57 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ftnn4d0u3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:54:57 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 10:54:55 -0000
Date: Tue, 30 Jan 2018 12:54:50 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] mm documentation
References: <20180130105237.GB7201@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130105237.GB7201@rapoport-lnx>
Message-Id: <20180130105450.GC7201@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

(forgot to CC linux-mm)

On Tue, Jan 30, 2018 at 12:52:37PM +0200, Mike Rapoport wrote:
> Hello,
> 
> The mm kernel-doc documentation is not in a great shape. 
> 
> Some of the existing kernel-doc annotations were not reformatted during
> transition from dockbook to sphix. Sometimes the parameter descriptions
> do not match actual code. But aside these rather mechanical issues there
> are several points it'd like to discuss:
> 
> * Currently, only 14 files are linked to kernel-api.rst under "Memory
> Management in Linux" section. We have more than hundred files only in mm.
> Even the existing documentation is not generated when running "make
> htmldocs"
> * Do we want to keep "Memory Management in Linux" under kernel-api.rst or
> maybe it's worth adding, say, mm.rst?
> * What is the desired layout of the documentation, what sections we'd like
> to have, how the documentation should be ordered?
> 
> -- 
> Sincerely yours,
> Mike.

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
