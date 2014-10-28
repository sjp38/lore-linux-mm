Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id AFD32900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 06:55:05 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id h11so1126159wiw.12
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:55:05 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id di9si13831441wib.52.2014.10.28.03.55.03
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 03:55:04 -0700 (PDT)
Date: Tue, 28 Oct 2014 12:54:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
Message-ID: <20141028105458.GA9768@node.dhcp.inet.fi>
References: <1254279794.1957.1414240389301.JavaMail.zimbra@efficios.com>
 <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lttng-dev <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Oct 25, 2014 at 12:51:25PM +0000, Mathieu Desnoyers wrote:
> FYI, the main reason why my customer wants to go with a
> "trace into memory that survives soft reboot" approach
> rather than to use things like kexec/kdump is that they
> care about the amount of time it takes to reboot their
> machines. They want a solution where they can extract the
> detailed crash data after reboot, after the machine is
> back online, rather than requiring a few minutes of offline
> time to extract the crash details.

IIRC, on x86 there's no guarantee that your memory content will be
preserved over reboot. BIOS is free to mess with it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
