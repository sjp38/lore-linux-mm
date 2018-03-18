Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADE16B0003
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 20:49:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az5-v6so7878273plb.14
        for <linux-mm@kvack.org>; Sat, 17 Mar 2018 17:49:54 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id u7-v6si4612545plr.293.2018.03.17.17.49.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Mar 2018 17:49:52 -0700 (PDT)
Subject: Re: [PATCH 1/3] x86, pkeys: do not special case protection key 0
References: <20180316214654.895E24EC@viggo.jf.intel.com>
 <20180316214656.0E059008@viggo.jf.intel.com>
 <20180317232425.GH1060@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f3de330c-e0b4-2210-1a93-f0fb6b5a5b3c@intel.com>
Date: Sat, 17 Mar 2018 17:49:51 -0700
MIME-Version: 1.0
In-Reply-To: <20180317232425.GH1060@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 03/17/2018 04:24 PM, Ram Pai wrote:
> So the difference between the two proposals is just the freeing part i.e (b).
> Did I get this right?

Yeah, I think that's the only difference.
