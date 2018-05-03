Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5580F6B0012
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:59:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f6-v6so7859579pgs.13
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:59:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b39-v6si14016673plb.456.2018.05.03.07.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:59:51 -0700 (PDT)
Date: Thu, 3 May 2018 10:59:46 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 2/9] mm: Prefix vma_ to vaddr_to_offset() and
 offset_to_vaddr()
Message-ID: <20180503105946.08decc47@gandalf.local.home>
In-Reply-To: <20180417043244.7501-3-ravi.bangoria@linux.vnet.ibm.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180417043244.7501-3-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

On Tue, 17 Apr 2018 10:02:37 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
>=20
> Make function names more meaningful by adding vma_ prefix
> to them.

Actually, I would have done this patch before the first one, since the
first one makes the functions global.

-- Steve

>=20
> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>
