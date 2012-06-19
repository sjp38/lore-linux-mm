Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 8E84C6B0069
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:12:22 -0400 (EDT)
Received: by dakp5 with SMTP id p5so10893300dak.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:12:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120619060945.GA8724@shangw>
References: <1339623535.3321.4.camel@lappy>
	<20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	<1339667440.3321.7.camel@lappy>
	<20120618223203.GE32733@google.com>
	<1340059850.3416.3.camel@lappy>
	<20120619041154.GA28651@shangw>
	<CAE9FiQVitg0ODjph96LnPD6pnWSSN8QkFngEwbUX9-nT-sdy+g@mail.gmail.com>
	<20120619060945.GA8724@shangw>
Date: Tue, 19 Jun 2012 11:12:21 -0700
Message-ID: <CAE9FiQXgkV0Fhg_dRNL95xQfXVLUG+h07xxmdX3dCQ0szaty6g@mail.gmail.com>
Subject: Re: Early boot panic on machine with lots of memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jun 18, 2012 at 11:09 PM, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> Yinghai, it's possible the memory block returned to bootmem and get used/corrupted
> by other CPU cores?

At that point only BSP is running.  and all APs are not started yet.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
