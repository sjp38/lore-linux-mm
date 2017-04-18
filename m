Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 040982806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:35:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o68so2790121pfj.20
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:35:07 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id n65si297969pgn.413.2017.04.18.14.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 14:35:07 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id c198so2472142pfc.1
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:35:07 -0700 (PDT)
Date: Tue, 18 Apr 2017 14:35:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/9] mm/huge_memory: Use zap_deposited_table() more
In-Reply-To: <20170411174233.21902-2-oohall@gmail.com>
Message-ID: <alpine.DEB.2.10.1704181434520.112481@chino.kir.corp.google.com>
References: <20170411174233.21902-1-oohall@gmail.com> <20170411174233.21902-2-oohall@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, arbab@linux.vnet.ibm.com, bsingharora@gmail.com, linux-nvdimm@lists.01.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Wed, 12 Apr 2017, Oliver O'Halloran wrote:

> Depending flags of the PMD being zapped there may or may not be a
> deposited pgtable to be freed. In two of the three cases this is open
> coded while the third uses the zap_deposited_table() helper. This patch
> converts the others to use the helper to clean things up a bit.
> 
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
