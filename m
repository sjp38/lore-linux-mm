Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED166B063A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 14:22:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x14-v6so9579088edr.7
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 11:22:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w58-v6si3005495edb.306.2018.11.08.11.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 11:22:37 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA8JJp0U118905
	for <linux-mm@kvack.org>; Thu, 8 Nov 2018 14:22:36 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nmrc5fvd0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Nov 2018 14:22:36 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 8 Nov 2018 19:22:34 -0000
Date: Thu, 8 Nov 2018 11:22:26 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
In-Reply-To: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
Message-Id: <20181108192226.GC5481@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, linuxppc-dev@lists.ozlabs.org

On Thu, Nov 08, 2018 at 01:05:09PM +0100, Florian Weimer wrote:
> Would it be possible to reserve a bit for PKEY_DISABLE_READ?
> 
> I think the POWER implementation can disable read access at the hardware
> level, but not write access, and that cannot be expressed with the
> current PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE bits.

POWER hardware can disable-read and can **also disable-write**
at the hardware level. It can disable-execute aswell at the
hardware level.   For example if the key bits for a given key in the AMR
register is  
	0b01  it is read-disable
	0b10  it is write-disable

To support access-disable, we make the key value 0b11.

So in case if you want to know if the key is read-disable 'bitwise-and' it
against 0x1.  i.e  (x & 0x1)

RP
