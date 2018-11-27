Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D334A6B48B3
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 10:31:41 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s14so14281168pfk.16
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 07:31:41 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s2si4054463pgj.60.2018.11.27.07.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 07:31:39 -0800 (PST)
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
 <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
 <87bm6zaa04.fsf@oldenburg.str.redhat.com>
 <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
 <87k1ln8o7u.fsf@oldenburg.str.redhat.com>
 <20181108201231.GE5481@ram.oc3035372033.ibm.com>
 <87bm6z71yw.fsf@oldenburg.str.redhat.com>
 <20181109180947.GF5481@ram.oc3035372033.ibm.com>
 <87efbqqze4.fsf@oldenburg.str.redhat.com>
 <20181127102350.GA5795@ram.oc3035372033.ibm.com>
 <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
Date: Tue, 27 Nov 2018 07:31:38 -0800
MIME-Version: 1.0
In-Reply-To: <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Ram Pai <linuxram@us.ibm.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 11/27/18 3:57 AM, Florian Weimer wrote:
> I would have expected something that translates PKEY_DISABLE_WRITE |
> PKEY_DISABLE_READ into PKEY_DISABLE_ACCESS, and also accepts
> PKEY_DISABLE_ACCESS | PKEY_DISABLE_READ, for consistency with POWER.
> 
> (My understanding is that PKEY_DISABLE_ACCESS does not disable all
> access, but produces execute-only memory.)

Correct, it disables all data access, but not execution.
