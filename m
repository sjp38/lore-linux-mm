Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD9796B02B2
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:45:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8-v6so18754205pgf.0
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:45:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m26si24364776pfa.45.2018.05.08.09.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 09:45:48 -0700 (PDT)
Subject: Re: [PATCH 5/8] x86/pkeys: Move vma_pkey() into asm/pkeys.h
References: <20180508145948.9492-1-mpe@ellerman.id.au>
 <20180508145948.9492-6-mpe@ellerman.id.au>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f9240079-2ff2-9d3f-ba15-fefe65c67779@intel.com>
Date: Tue, 8 May 2018 09:45:46 -0700
MIME-Version: 1.0
In-Reply-To: <20180508145948.9492-6-mpe@ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 05/08/2018 07:59 AM, Michael Ellerman wrote:
> Move the last remaining pkey helper, vma_pkey() into asm/pkeys.h

Fine with me, as long as it compiles. :)

Reviewed-by: Dave Hansen <dave.hansen@intel.com>
