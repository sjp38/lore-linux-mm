Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 66A456B003C
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:38:38 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so6015393pbc.1
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:38:37 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 07/13] KVM: PPC: enable IOMMU_API for KVM_BOOK3S_64 permanently
Date: Wed, 28 Aug 2013 18:37:44 +1000
Message-Id: <1377679070-3515-8-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

It does not make much sense to have KVM in book3s-64bit and
not to have IOMMU bits for PCI pass through support as it costs little
and allows VFIO to function on book3s-kvm.

Having IOMMU_API always enabled makes it unnecessary to have a lot of
"#ifdef IOMMU_API" in arch/powerpc/kvm/book3s_64_vio*. With those
ifdef's we could have only user space emulated devices accelerated
(but not VFIO) which do not seem to be very useful.

Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
---
 arch/powerpc/kvm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/kvm/Kconfig b/arch/powerpc/kvm/Kconfig
index c55c538..3b2b761 100644
--- a/arch/powerpc/kvm/Kconfig
+++ b/arch/powerpc/kvm/Kconfig
@@ -59,6 +59,7 @@ config KVM_BOOK3S_64
 	depends on PPC_BOOK3S_64
 	select KVM_BOOK3S_64_HANDLER
 	select KVM
+	select SPAPR_TCE_IOMMU
 	---help---
 	  Support running unmodified book3s_64 and book3s_32 guest kernels
 	  in virtual machines on book3s_64 host processors.
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
