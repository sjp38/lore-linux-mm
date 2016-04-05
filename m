Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7E86B026E
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 15:06:47 -0400 (EDT)
Received: by mail-qk0-f179.google.com with SMTP id o6so9094037qkc.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 12:06:47 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id f81si27363689qkb.82.2016.04.05.12.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 12:06:46 -0700 (PDT)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sukadev@linux.vnet.ibm.com>;
	Tue, 5 Apr 2016 13:06:45 -0600
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6C6BDC4000F
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 12:54:49 -0600 (MDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u35J6eu337421280
	for <linux-mm@kvack.org>; Tue, 5 Apr 2016 19:06:40 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u35J0vmq029660
	for <linux-mm@kvack.org>; Tue, 5 Apr 2016 15:00:57 -0400
Date: Tue, 5 Apr 2016 12:05:47 -0700
From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 1/1] powerpc/mm: Add memory barrier in __hugepte_alloc()
Message-ID: <20160405190547.GA12673@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, James Dykman <jdykman@us.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

