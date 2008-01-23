Subject: Re: [RFC] Userspace tracing memory mappings
References: <20080123160454.GA15405@Krystal>
From: fche@redhat.com (Frank Ch. Eigler)
Date: Wed, 23 Jan 2008 14:01:20 -0500
In-Reply-To: <20080123160454.GA15405@Krystal> (Mathieu Desnoyers's message of "Wed, 23 Jan 2008 11:04:54 -0500")
Message-ID: <y0m3aso9xj3.fsf@ton.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Dave Hansen <haveblue@us.ibm.com>, mbligh@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> writes:

> [...]  Since memory management is not my speciality, I would like to
> know if there are some implementation details I should be aware of
> for my LTTng userspace tracing buffers. Here is what I want to do
> [...]

Would you mind offering some justification for requiring a kernel
extension for user-space tracing?  What can the kernel enable in this
context that a user-space library (which you already assume will be
linked in) can't?

- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
