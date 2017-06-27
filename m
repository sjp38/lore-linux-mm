Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 716406B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:33:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v36so24941420pgn.6
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:33:42 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id g5si1937969plj.193.2017.06.27.04.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 04:33:41 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id u62so3998181pgb.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:33:41 -0700 (PDT)
Message-ID: <1498563169.7935.16.camel@gmail.com>
Subject: Re: [RFC v4 02/17] mm: ability to disable execute permission on a
 key at creation
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 27 Jun 2017 21:32:49 +1000
In-Reply-To: <1498558319-32466-3-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
	 <1498558319-32466-3-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, 2017-06-27 at 03:11 -0700, Ram Pai wrote:
> Currently sys_pkey_create() provides the ability to disable read
> and write permission on the key, at  creation. powerpc  has  the
> hardware support to disable execute on a pkey as well.This patch
> enhances the interface to let disable execute  at  key  creation
> time. x86 does  not  allow  this.  Hence the next patch will add
> ability  in  x86  to  return  error  if  PKEY_DISABLE_EXECUTE is
> specified.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
