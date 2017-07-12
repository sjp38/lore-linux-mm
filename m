Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 794A7440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 18:40:54 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 64so13564280uag.8
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 15:40:54 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id g189si1345874vkb.290.2017.07.12.15.40.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 15:40:52 -0700 (PDT)
Message-ID: <1499899228.2865.43.camel@kernel.crashing.org>
Subject: Re: [RFC v5 11/38] mm: introduce an additional vma bit for powerpc
 pkey
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 13 Jul 2017 08:40:28 +1000
In-Reply-To: <20170712222331.GD5525@ram.oc3035372033.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
	 <1499289735-14220-12-git-send-email-linuxram@us.ibm.com>
	 <290636b0-aafd-9bcd-d309-4cff41ce923c@intel.com>
	 <20170712222331.GD5525@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed, 2017-07-12 at 15:23 -0700, Ram Pai wrote:
> Just copying over makes checkpatch.pl unhappy. It exceeds 80 columns.

Which is fine to ignore in a case like that where you remain consistent
with the existing code.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
