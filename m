Message-ID: <46A0E2A9.6000308@s5r6.in-berlin.de>
Date: Fri, 20 Jul 2007 18:28:25 +0200
From: Stefan Richter <stefanr@s5r6.in-berlin.de>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
References: <20070531002047.702473071@sgi.com>	 <20070531003012.302019683@sgi.com> <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>
In-Reply-To: <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satyam Sharma <satyam.sharma@gmail.com>
Cc: "clameter@sgi.com" <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Chris Snook <csnook@redhat.com>
List-ID: <linux-mm.kvack.org>

(I missed the original post, hence am replying to te reply...)
> On 5/31/07, clameter@sgi.com <clameter@sgi.com> wrote:
>> Introduce CONFIG_STABLE to control checks only useful for development.
>>
>> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>> [...]
>>  menu "General setup"
>>
>> +config STABLE
>> +       bool "Stable kernel"
>> +       help
>> +         If the kernel is configured to be a stable kernel then various
>> +         checks that are only of interest to kernel development will be
>> +         omitted.
>> +

Didn't we talk about the wording and the logic some time ago?  Your
option looks like a magic switch that suddenly improves kernel
stability, hence everyone will switch it on.

How about this:

config BUILD_FOR_RELEASE
	bool "Build for release"
	help
	  If the kernel is configured as a release build, various checks
	  that are only of interest to kernel development will be
	  omitted.

	  If unsure, say Y.

Or this:

config BUILD_FOR_TESTING
	bool "Build for testing"
	help
	  If the kernel is configured as a test build, various checks
	  useful for testing of pre-releases will be activated.

	  If unsure, say N.
-- 
Stefan Richter
-=====-=-=== -=== =-=--
http://arcgraph.de/sr/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
