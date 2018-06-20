Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73E4E6B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:57:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 70-v6so1993975plc.1
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:57:15 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q86-v6si2564820pfg.298.2018.06.20.07.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 07:57:14 -0700 (PDT)
Subject: Re: [PATCH v13 14/24] selftests/vm: generic cleanup
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-15-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e50fa00b-724e-ebcb-38b4-22cad9bee1c5@intel.com>
Date: Wed, 20 Jun 2018 07:57:11 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-15-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/13/2018 05:45 PM, Ram Pai wrote:
> cleanup the code to satisfy coding styles.

A lot of this makes the code look worse and more unreadable than before.
 I think someone just ran it through lindent or something.

I also took a few CodingStyle liberties in here because it's _not_ main
kernel code.  I think the occasional 85-column line is probably OK in here.
