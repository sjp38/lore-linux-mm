Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9971A6B0012
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 20:44:53 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e6so8830869qkf.19
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 17:44:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z3si1278016qti.454.2018.03.23.17.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 17:44:52 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2O0hucg123748
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 20:44:51 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gw7n10vk1-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 20:44:51 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 24 Mar 2018 00:44:49 -0000
Date: Fri, 23 Mar 2018 17:44:40 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
 <871sguep4v.fsf@concordia.ellerman.id.au>
 <20180308164545.GM1060@ram.oc3035372033.ibm.com>
 <CAEemH2czWDjvJLpL6ynV1+VxCFh_-A-d72tJhA5zwgrAES2nWA@mail.gmail.com>
 <20180320215828.GA5825@ram.oc3035372033.ibm.com>
 <CAEemH2eewab4nsn6daMRAtn9tDrHoZb_PnbH8xA17ypFCTg6iA@mail.gmail.com>
 <20180322070900.GA5605@ram.oc3035372033.ibm.com>
 <CAEemH2c4p7FqYs9L9X0SyjUvg5Z3pfwsokurJmzq+=y1h2OwbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEemH2c4p7FqYs9L9X0SyjUvg5Z3pfwsokurJmzq+=y1h2OwbA@mail.gmail.com>
Message-Id: <20180324004440.GA5887@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Cyril Hrubis <chrubis@suse.cz>, Jan Stancek <jstancek@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, ltp@lists.linux.it, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Fri, Mar 23, 2018 at 05:27:06PM +0800, Li Wang wrote:
>    On Thu, Mar 22, 2018 at 3:09 PM, Ram Pai <[1]linuxram@us.ibm.com> wrote:
> 
>      On Wed, Mar 21, 2018 at 02:53:00PM +0800, Li Wang wrote:
>      >A  A  On Wed, Mar 21, 2018 at 5:58 AM, Ram Pai
>      <[1][2]linuxram@us.ibm.com> wrote:
>      >A  A  that why not disable the pkey_execute_disable_supported on p8
.snip..

>      machine?
> 
>      It turns out to be a testcase bug.A  On Big endian powerpc ABI, function
>      ptrs are basically pointers to function descriptors.A  The testcase
>      copies functions which results in function descriptors getting copied.
>      You have to apply the following patch to your test case for it to
>      operate as intended.A  Thanks to Michael Ellermen for helping me out.
>      Otherwise I would be scratching my head for ever.
> 
>    a??Thanks for the explanation, I learned something new about this. :)
> 
>    And the worth to say, seems the patch only works on powerpc arch,
>    others(x86_64, etc)
>    that does not works well, so a simple workaround is to isolate the code
>    changes
>    to powerpc system?

yes. this code has to be made applicable to powerpc Big-endian code
only.  The powerpc little-endian code remains unchanged.

RP
