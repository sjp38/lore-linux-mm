Date: Thu, 24 Jan 2008 09:53:43 -0800
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [kvm-devel] [RFC][PATCH 3/5] ksm source code
Message-ID: <20080124175343.GS3627@sequoia.sous-sol.org>
References: <4794C477.3090708@qumranet.com> <20080124072432.GQ3627@sequoia.sous-sol.org> <4798554D.1010300@qumranet.com> <479858CE.3060704@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <479858CE.3060704@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Izik Eidus <izike@qumranet.com>, Chris Wright <chrisw@sous-sol.org>, kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

* Avi Kivity (avi@qumranet.com) wrote:
> Actually the entire contents of 'struct ksm' should be module static 
> variables.

Yeah, I agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
