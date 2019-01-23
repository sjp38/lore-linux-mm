Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C90838E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:04:31 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so1626807ply.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 07:04:31 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a8si16545736pgw.380.2019.01.23.07.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 07:04:30 -0800 (PST)
Date: Wed, 23 Jan 2019 10:03:36 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH v7 09/16] mm: add a user_virt_to_phys symbol
Message-ID: <20190123150248.GE19289@Konrads-MacBook-Pro.local>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <c9a409397fc608f7ae6297597d9ea3d21eeb3b38.1547153058.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9a409397fc608f7ae6297597d9ea3d21eeb3b38.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org

> +EXPORT_SYMBOL(user_virt_to_phys);

Could it be _GPL? OTherwise looks OK to me.
