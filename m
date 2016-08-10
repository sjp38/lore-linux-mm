Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC866B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 14:44:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so71298865wml.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 11:44:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ht7si39496622wjb.52.2016.08.10.11.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 11:44:07 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7AIi0kB061530
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 14:44:05 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qm9v35aa-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 14:44:05 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 12:44:04 -0600
Date: Wed, 10 Aug 2016 13:43:58 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] powerpc/mm: movable hotplug memory nodes
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <87shucsypn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87shucsypn.fsf@concordia.ellerman.id.au>
Message-Id: <20160810184357.GB12039@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 10, 2016 at 08:30:28PM +1000, Michael Ellerman wrote:
>Reza Arbab <arbab@linux.vnet.ibm.com> writes:
>> Node hotplug is not supported on power [1].
>
>But maybe it should be?

Doing so will involve, at the very least, reverting the commit I cited, 
3af229f2071f ("powerpc/numa: Reset node_possible_map to only 
node_online_map"), and fixing that issue in a different way.

I'll look into it and see what I can do.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
