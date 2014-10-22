From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 3/4] s390/mm: prevent and break zero page mappings in
 case of storage keys
Date: Wed, 22 Oct 2014 12:09:07 +0200
Message-ID: <54478243.7010108@redhat.com>
References: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com> <1413966624-12447-4-git-send-email-dingel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1413966624-12447-4-git-send-email-dingel@linux.vnet.ibm.com>
Sender: kvm-owner@vger.kernel.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.orglinux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On 10/22/2014 10:30 AM, Dominik Dingel wrote:
> As use_skey is already the condition on which we call s390_enable_skey
> we need to introduce a new flag for the mm->context on which we decide
> if zero page mapping is allowed.

Can you explain better why "mm->context.use_skey = 1" cannot be done
before the walk_page_range?  Where does the walk or __s390_enable_skey
or (after the next patch) ksm_madvise rely on
"mm->context.forbids_zeropage && !mm->context.use_skey"?

The only reason I can think of, is that the next patch does not reset
"mm->context.forbids_zeropage" to 0 if the ksm_madvise fails.  Why
doesn't it do that---or is it a bug?

Thanks, and sorry for the flurry of questions! :)

Paolo

