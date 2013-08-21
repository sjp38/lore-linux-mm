Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 9858D6B00B0
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 11:22:11 -0400 (EDT)
Message-ID: <5214DB1B.6070803@redhat.com>
Date: Wed, 21 Aug 2013 17:22:03 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add overcommit_kbytes sysctl variable
References: <1376925478-15506-1-git-send-email-jmarchan@redhat.com> <1376925478-15506-2-git-send-email-jmarchan@redhat.com> <52124DE7.8070502@intel.com>
In-Reply-To: <52124DE7.8070502@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/19/2013 06:55 PM, Dave Hansen wrote:
> On 08/19/2013 08:17 AM, Jerome Marchand wrote:
>> Some applications that run on HPC clusters are designed around the
>> availability of RAM and the overcommit ratio is fine tuned to get the
>> maximum usage of memory without swapping. With growing memory, the
>> 1%-of-all-RAM grain provided by overcommit_ratio has become too coarse
>> for these workload (on a 2TB machine it represents no less than
>> 20GB).
>>
>> This patch adds the new overcommit_kbytes sysctl variable that allow a
>> much finer grain.
> 
> Instead of introducing yet another tunable, why don't we just make the
> ratio that comes in from the user more fine-grained?
> 
> 	sysctl overcommit_ratio=0.2
> 
> We change the internal 'sysctl_overcommit_ratio' to store tenths or
> hundreths of a percent (or whatever), then parse the input as two
> integers.  I don't think we need fully correct floating point parsing
> and rounding here, so it shouldn't be too much of a chore.  It'd
> probably end up being less code than you have as it stands.
> 

Now that I think about it, that could break user space. Sure write access
wouldn't be a problem (one can still write a plain integer), but a script
that reads a fractional value when it expects an integer might not be able
to cope with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
