Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 209B66B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:12:27 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id y19so20227020wgg.4
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:12:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si3761537wic.38.2015.01.16.04.12.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 04:12:26 -0800 (PST)
Message-ID: <54B90027.5040103@suse.de>
Date: Fri, 16 Jan 2015 13:12:23 +0100
From: Alexander Graf <agraf@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] current ACCESS_ONCE patch queue
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org



On 15.01.15 09:58, Christian Borntraeger wrote:
> Folks,
> 
> fyi, this is my current patch queue for the next merge window. It
> does contain a patch that will disallow ACCESS_ONCE on non-scalar
> types.
> 
> The tree is part of linux-next and can be found at
> git://git.kernel.org/pub/scm/linux/kernel/git/borntraeger/linux.git linux-next

KVM PPC bits are:

 Acked-by: Alexander Graf <agraf@suse.de>



Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
