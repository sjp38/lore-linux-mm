Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 887B66B0012
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 13:51:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w17so429834qkb.19
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 10:51:39 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0076.outbound.protection.outlook.com. [104.47.33.76])
        by mx.google.com with ESMTPS id k67si1982767qkd.372.2018.03.25.10.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 25 Mar 2018 10:51:38 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 1/2] rcu: declare rcu_eqs_special_set() in public header
Date: Sun, 25 Mar 2018 20:50:03 +0300
Message-Id: <20180325175004.28162-2-ynorov@caviumnetworks.com>
In-Reply-To: <20180325175004.28162-1-ynorov@caviumnetworks.com>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

rcu_eqs_special_set() is declared only in internal header
kernel/rcu/tree.h and stubbed in include/linux/rcutiny.h.

This patch declares rcu_eqs_special_set() in include/linux/rcutree.h, so
it can be used in non-rcu kernel code.

Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 include/linux/rcutree.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index fd996cdf1833..448f20f27396 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -74,6 +74,7 @@ static inline void synchronize_rcu_bh_expedited(void)
 void rcu_barrier(void);
 void rcu_barrier_bh(void);
 void rcu_barrier_sched(void);
+bool rcu_eqs_special_set(int cpu);
 unsigned long get_state_synchronize_rcu(void);
 void cond_synchronize_rcu(unsigned long oldstate);
 unsigned long get_state_synchronize_sched(void);
-- 
2.14.1
