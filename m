Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15DC66B0497
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:24:48 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id a28-v6so3488686ljd.6
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:24:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2-v6sor12875828ljc.10.2018.10.29.11.24.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:24:46 -0700 (PDT)
Subject: Re: [PATCH 09/17] prmem: hardened usercopy
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-10-igor.stoppa@huawei.com>
 <cd768a99-5afa-999c-989a-efee66fa0ddb@redhat.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <d1f3f3b3-80b5-c194-dae7-b192e43a9dd1@gmail.com>
Date: Mon, 29 Oct 2018 20:24:43 +0200
MIME-Version: 1.0
In-Reply-To: <cd768a99-5afa-999c-989a-efee66fa0ddb@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: crecklin@redhat.com, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 29/10/2018 11:45, Chris von Recklinghausen wrote:

[...]

> Could you add code somewhere (lkdtm driver if possible) to demonstrate
> the issue and verify the code change?

Sure.

Eventually, I'd like to add test cases for each functionality.
I didn't do it right away for those parts which are either not 
immediately needed for the main functionality or I'm still not confident 
enough that they won't change radically.

--

igor
