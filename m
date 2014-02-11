Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id C00E06B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:04:02 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id e16so6004792lan.26
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:04:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si10389016lal.22.2014.02.11.09.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 09:04:00 -0800 (PST)
Date: Tue, 11 Feb 2014 17:03:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: dirty accountable change only apply to non prot
 numa case
Message-ID: <20140211170357.GL6732@suse.de>
References: <1392114895-14997-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1392114895-14997-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1392114895-14997-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Feb 11, 2014 at 04:04:54PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> So move it within the if loop
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
