Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 047268E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 14:57:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so11125829pgp.3
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 11:57:51 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x4-v6si16168531plo.459.2018.09.10.11.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 11:57:50 -0700 (PDT)
Subject: Re: [RFC 09/12] mm: Restrict memory encryption to anonymous VMA's
References: <cover.1536356108.git.alison.schofield@intel.com>
 <f69e3d4f96504185054d951c7c85075ebf63e47a.1536356108.git.alison.schofield@intel.com>
 <ae0288d5205a5c431e9a6bf0c9e68beded45e84b.camel@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <84154fd2-7c27-0fd2-f339-15e144a5df49@intel.com>
Date: Mon, 10 Sep 2018 11:57:49 -0700
MIME-Version: 1.0
In-Reply-To: <ae0288d5205a5c431e9a6bf0c9e68beded45e84b.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On 09/10/2018 11:21 AM, Sakkinen, Jarkko wrote:
>> +/*
>> + * Encrypted mprotect is only supported on anonymous mappings.
>> + * All VMA's in the requested range must be anonymous. If this
>> + * test fails on any single VMA, the entire mprotect request fails.
>> + */
> kdoc

kdoc what?  You want this comment in kdoc format?  Why?
