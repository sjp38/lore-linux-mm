Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED046B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:42:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z16-v6so2739962pgv.16
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:42:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h33-v6si13709599plh.483.2018.05.03.07.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:42:10 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
 <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <a37b7deb-7f5a-3dfa-f360-956cab8a813a@intel.com>
 <CALCETrUM7wWZh55gaLiAoPqtxLLUJ4QC8r8zj62E9avJ6ZVu0w@mail.gmail.com>
 <f9f7edc5-6426-91aa-f279-2f9f4671957a@intel.com>
 <2BE03B9A-B1E0-4707-8705-203F88B62A1C@amacapital.net>
 <cf71c470-9712-ce7c-a84a-f78468ebb4a8@intel.com>
 <AE502DA2-5B8E-4144-937F-E39DCCC57540@amacapital.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <99bb879a-6655-33bf-9521-39466f73b8b8@intel.com>
Date: Thu, 3 May 2018 07:42:08 -0700
MIME-Version: 1.0
In-Reply-To: <AE502DA2-5B8E-4144-937F-E39DCCC57540@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On 05/02/2018 06:14 PM, Andy Lutomirski wrote:
>> I think you are saying: If a thread calls pkey_alloc(), all
>> threads should, by default, implicitly get access.
> No, Ia??m saying that all threads should get the *requested* access.
> If Ia??m protecting the GOT, I want all threads to get RO access. If
> Ia??m writing a crypto library, I probably want all threads to have no
> access.  If Ia??m writing a database, I probably want all threads to
> get RO by default.  If Ia??m writing some doodad to sandbox some
> carefully constructed code, I might want all threads to have full
> access by default.

OK, fair enough.  I totally agree that the current interface (or
architecture for that matter) is not amenable to use models where we are
implicitly imposing policies on *other* threads.

I don't think that means the current stuff is broken for
multi-threading, though, just the (admittedly useful) cases you are
talking about where you want to poke at a remote thread's PKRU.

So, where do we go from here?
