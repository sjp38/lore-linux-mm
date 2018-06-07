Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 994816B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:48:09 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so6178690plv.0
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:48:09 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j66-v6si6075133pfc.243.2018.06.07.15.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:48:08 -0700 (PDT)
Subject: Re: [PATCH v4 1/4] mm/sparse: Add a static variable
 nr_present_sections
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-2-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cd3e1821-5e89-97a5-f108-d67e819cc209@intel.com>
Date: Thu, 7 Jun 2018 15:46:46 -0700
MIME-Version: 1.0
In-Reply-To: <20180521101555.25610-2-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 05/21/2018 03:15 AM, Baoquan He wrote:
> It's used to record how many memory sections are marked as present
> during system boot up, and will be used in the later patch.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

I think this is fine:

Acked-By: Dave Hansen <dave.hansen@intel.com>
