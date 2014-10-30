Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id BEEFC90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 11:11:44 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so4496994lbv.0
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:11:43 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id rs4si12543547lbb.12.2014.10.30.08.11.41
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 08:11:42 -0700 (PDT)
Date: Thu, 30 Oct 2014 15:11:36 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <864133911.4806.1414681896478.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141028105458.GA9768@node.dhcp.inet.fi>
References: <1254279794.1957.1414240389301.JavaMail.zimbra@efficios.com> <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com> <20141028105458.GA9768@node.dhcp.inet.fi>
Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lttng-dev <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>

----- Original Message -----
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <willy@linux.intel.com>, "Ross Zwisler" <ross.zwisler@linux.intel.com>, "lttng-dev"
> <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Sent: Tuesday, October 28, 2014 6:54:58 AM
> Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
> 
> On Sat, Oct 25, 2014 at 12:51:25PM +0000, Mathieu Desnoyers wrote:
> > FYI, the main reason why my customer wants to go with a
> > "trace into memory that survives soft reboot" approach
> > rather than to use things like kexec/kdump is that they
> > care about the amount of time it takes to reboot their
> > machines. They want a solution where they can extract the
> > detailed crash data after reboot, after the machine is
> > back online, rather than requiring a few minutes of offline
> > time to extract the crash details.
> 
> IIRC, on x86 there's no guarantee that your memory content will be
> preserved over reboot. BIOS is free to mess with it.

Hi Kirill,

This is a good point,

There are a few more aspects to consider here:

- Other architectures appear to have different guarantees, for
  instance ARM which, AFAIK, does not reset memory on soft
  reboot (well at least for my customer's boards). So I guess
  if x86 wants to be competitive, it would be good for them to
  offer a similar feature,

- Already having a subset of machines supporting this is useful,
  e.g. storing trace buffers and recovering them after a crash,

- Since we are in a world of dynamically upgradable BIOS, perhaps
  if we can show that there is value in having a BIOS option to
  specify a memory range that should not be reset on soft reboot,
  BIOS vendors might be inclined to include an option for it,

- Perhaps UEFI BIOS already have some way of specifying that a
  memory range should not be reset on soft reboot ?

Thoughts ?

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
