Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4386B02F3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:05:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 184so19023147wmo.7
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:05:52 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id j72si18726435wrj.127.2017.07.27.05.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:58:37 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id q189so12484700wmd.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:58:37 -0700 (PDT)
Date: Thu, 27 Jul 2017 15:58:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/3] powerpc/mm: update pmdp_invalidate to return old
 pmd value
Message-ID: <20170727125835.4vtk25cttgs5awk2@node.shutemov.name>
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727125449.GB27766@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727125449.GB27766@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Jul 27, 2017 at 02:54:49PM +0200, Michal Hocko wrote:
> EMISSING_CHANGELOG
> 
> besides that no user actually uses the return value. Please fold this
> into the patch which uses the new functionality.

That's for patchset I'm working on[1].

[1] http://lkml.kernel.org/r/20170615145224.66200-1-kirill.shutemov@linux.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
