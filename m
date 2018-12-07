Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7BA6B7E37
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 23:23:57 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so1814765ple.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 20:23:57 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x66si2116896pfk.73.2018.12.06.20.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 20:23:56 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
 <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
 <1544147742.28511.18.camel@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7ac80308-1831-fe42-9c53-05f913cba403@intel.com>
Date: Thu, 6 Dec 2018 20:23:54 -0800
MIME-Version: 1.0
In-Reply-To: <1544147742.28511.18.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>, "luto@kernel.org" <luto@kernel.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "peterz@infradead.org" <peterz@infradead.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "bp@alien8.de" <bp@alien8.de>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On 12/6/18 5:55 PM, Huang, Kai wrote:
> I think one usage of user-specified key is for NVDIMM, since CPU key
> will be gone after machine reboot, therefore if NVDIMM is encrypted
> by CPU key we are not able to retrieve it once shutdown/reboot, etc.

I think we all agree that the NVDIMM uses are really useful.

But, these patches don't implement that.  So, if NVDIMMs are the only
reasonable use case, we shouldn't merge these patches until we add
NVDIMM support.
